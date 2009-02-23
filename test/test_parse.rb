require File.join(File.dirname(__FILE__), 'helper')

class TestParse < Test::Unit::TestCase
  test "ping-pong" do
    bot = mock_bot {}
    bot_is_connected

    bot.irc.parse "PING :foo.bar"
    assert_equal "PONG :foo.bar\n", @server.gets
  end

  test "private messages dispatches private event" do
    bot = mock_bot {
      on(:private, //) {msg "foo", "bar baz"}
    }
    bot_is_connected

    bot.irc.parse ":johnny!john@doe.com PRIVMSG isaac :hello, you!"
    assert_equal "PRIVMSG foo :bar baz\n", @server.gets
  end

  test "channel messages dispatches channel event" do
    bot = mock_bot {
      on(:channel, //) {msg "foo", "bar baz"}
    }
    bot_is_connected

    bot.irc.parse ":johnny!john@doe.com PRIVMSG #awesome :hello, folks!"
    assert_equal "PRIVMSG foo :bar baz\n", @server.gets
  end

  test "private event has environment" do
    bot = mock_bot {
      on :private, // do
        assert_equal "johnny", nick
        assert_equal "john@doe.com", userhost
        assert_equal "hello, you!", message
      end
    }
    bot_is_connected

    bot.irc.parse ":johnny!john@doe.com PRIVMSG isaac :hello, you!"
  end

  test "channel event has environment" do
    bot = mock_bot {
      on :channel, // do
        assert_equal "johnny", nick
        assert_equal "john@doe.com", userhost
        assert_equal "hello, folks!", message
        assert_equal "#awesome", channel
      end
    }
    bot_is_connected

    bot.irc.parse ":johnny!john@doe.com PRIVMSG #awesome :hello, folks!"
  end

  test "errors are caught and dispatched" do
    bot = mock_bot {
      on(:error, 401) {
        assert_equal 401, error
        assert_equal "jeff", nick
        assert_equal "jeff", channel
      }
    }
    bot_is_connected

    bot.irc.parse ":server 401 isaac jeff :No such nick/channel"
  end
end
