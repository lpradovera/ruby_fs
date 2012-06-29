require 'spec_helper'

module RubyFS
  describe Stream do
    let(:server_port) { 50000 - rand(1000) }

    before do
      def client.message_received(message)
        @messages ||= Queue.new
        @messages << message
      end

      def client.messages
        @messages
      end
    end

    let :client_messages do
      messages = []
      messages << client.messages.pop until client.messages.empty?
      messages
    end

    def mocked_server(times = nil, fake_client = nil, &block)
      mock_target = MockServer.new
      mock_target.expects(:receive_data).send(*(times ? [:times, times] : [:at_least, 1])).with &block
      s = ServerMock.new '127.0.0.1', server_port, mock_target
      @stream = Stream.new '127.0.0.1', server_port, lambda { |m| client.message_received m }
      fake_client.call if fake_client.respond_to? :call
      s.join
      @stream.join
    end

    def expect_connected_event
      client.expects(:message_received).with Stream::Connected.new
    end

    def expect_disconnected_event
      client.expects(:message_received).with Stream::Disconnected.new
    end

    before { @sequence = 1 }

    describe "after connection" do
      it "should be started" do
        expect_connected_event
        expect_disconnected_event
        mocked_server(0) do |val, server|
          @stream.started?.should be_true
        end
      end

      it "can send data" do
        expect_connected_event
        expect_disconnected_event
        mocked_server(1, lambda { @stream.send_data "foo" }) do |val, server|
          val.should == "foo"
        end
      end
    end

    it 'sends events to the client when the stream is ready' do
      mocked_server(1, lambda { @stream.send_data 'Foo' }) do |val, server|
        server.send_data %Q(
Content-Length: 776
Content-Type: text/event-json

{
 "Event-Name": "HEARTBEAT",
 "Core-UUID": "2ad09a34-c056-11e1-b095-fffeda3ce54f",
 "FreeSWITCH-Hostname": "blmbp.home",
 "FreeSWITCH-Switchname": "blmbp.home",
 "FreeSWITCH-IPv4": "192.168.1.74",
 "FreeSWITCH-IPv6": "::1",
 "Event-Date-Local": "2012-06-27 19:43:32",
 "Event-Date-GMT": "Wed, 27 Jun 2012 18:43:32 GMT",
 "Event-Date-Timestamp": "1340822612392823",
 "Event-Calling-File": "switch_core.c",
 "Event-Calling-Function": "send_heartbeat",
 "Event-Calling-Line-Number": "68",
 "Event-Sequence": "3526",
 "Event-Info": "System Ready",
 "Up-Time": "0 years, 0 days, 5 hours, 56 minutes, 40 seconds, 807 milliseconds, 21 microseconds",
 "Session-Count": "0",
 "Max-Sessions": "1000",
 "Session-Per-Sec": "30",
 "Session-Since-Startup": "4",
 "Idle-CPU": "100.000000"
}Content-Length: 629
Content-Type: text/event-json

{
 "Event-Name": "RE_SCHEDULE",
 "Core-UUID": "2ad09a34-c056-11e1-b095-fffeda3ce54f",
 "FreeSWITCH-Hostname": "blmbp.home",
 "FreeSWITCH-Switchname": "blmbp.home",
 "FreeSWITCH-IPv4": "192.168.1.74",
 "FreeSWITCH-IPv6": "::1",
 "Event-Date-Local": "2012-06-27 19:43:32",
 "Event-Date-GMT": "Wed, 27 Jun 2012 18:43:32 GMT",
 "Event-Date-Timestamp": "1340822612392823",
 "Event-Calling-File": "switch_scheduler.c",
 "Event-Calling-Function": "switch_scheduler_execute",
 "Event-Calling-Line-Number": "65",
 "Event-Sequence": "3527",
 "Task-ID": "2",
 "Task-Desc": "heartbeat",
 "Task-Group": "core",
 "Task-Runtime": "1340822632"
})
      end

      client_messages.should be == [
        Stream::Connected.new,
        Event.new({:content_length => '776', :content_type => 'text/event-json'}, {:event_name => "HEARTBEAT", :core_uuid => "2ad09a34-c056-11e1-b095-fffeda3ce54f", :freeswitch_hostname => "blmbp.home", :freeswitch_switchname => "blmbp.home", :freeswitch_ipv4 => "192.168.1.74", :freeswitch_ipv6 => "::1", :event_date_local => "2012-06-27 19:43:32", :event_date_gmt => "Wed, 27 Jun 2012 18:43:32 GMT", :event_date_timestamp => "1340822612392823", :event_calling_file => "switch_core.c", :event_calling_function => "send_heartbeat", :event_calling_line_number => "68", :event_sequence => "3526", :event_info => "System Ready", :up_time => "0 years, 0 days, 5 hours, 56 minutes, 40 seconds, 807 milliseconds, 21 microseconds", :session_count => "0", :max_sessions => "1000", :session_per_sec => "30", :session_since_startup => "4", :idle_cpu => "100.000000"}),
        Event.new({:content_length => '629', :content_type => 'text/event-json'}, {:event_name => "RE_SCHEDULE", :core_uuid => "2ad09a34-c056-11e1-b095-fffeda3ce54f", :freeswitch_hostname => "blmbp.home", :freeswitch_switchname => "blmbp.home", :freeswitch_ipv4 => "192.168.1.74", :freeswitch_ipv6 => "::1", :event_date_local => "2012-06-27 19:43:32", :event_date_gmt => "Wed, 27 Jun 2012 18:43:32 GMT", :event_date_timestamp => "1340822612392823", :event_calling_file => "switch_scheduler.c", :event_calling_function => "switch_scheduler_execute", :event_calling_line_number => "65", :event_sequence => "3527", :task_id => "2", :task_desc => "heartbeat", :task_group => "core", :task_runtime => "1340822632"}),
        Stream::Disconnected.new
      ]
    end

    it 'puts itself in the stopped state and fires a disconnected event when unbound' do
      expect_connected_event
      expect_disconnected_event
      mocked_server(1, lambda { @stream.send_data 'Foo' }) do |val, server|
        @stream.stopped?.should be false
      end
      @stream.alive?.should be false
    end
  end
end