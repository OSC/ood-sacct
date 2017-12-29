require 'minitest_helper'
require 'command'

class TestCommand < Minitest::Test

  def test_command_output_parsing
    output = File.read("test/sacct.txt")
    processes = Command.new.parse(output)

    #assert_equal 1, processes.count
    #
    # 2074737|_mb_bot240520ps_|GPU|mc4sa9p|32|COMPLETED|0:0

    p = processes.first

    assert_equal "2074737", p.jobid
    assert_equal "_mb_bot240520ps_", p.jobname
    assert_equal "GPU", p.partition
    assert_equal "mc4sa9p", p.account
    assert_equal "32", p.cpus
    assert_equal "COMPLETED", p.state
    assert_equal "0:0", p.exit_code
  end
end
