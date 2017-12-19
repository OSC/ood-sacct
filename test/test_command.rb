require 'minitest_helper'
require 'command'

class TestCommand < Minitest::Test

  def test_command_output_parsing
    output = File.read("test/sacct.txt")
    processes = Command.new.parse(output)

    #assert_equal 1, processes.count

    p = processes.first

    assert_equal "1933171", p.jobid
    assert_equal "pbe_fe_2_+", p.jobname
    assert_equal "RM-shared", p.partition
    assert_equal "mr4s95p", p.account
    assert_equal "28", p.cpus
    assert_equal "RUNNING", p.state
    assert_equal "0:0", p.exit_code
  end
end
