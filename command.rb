require 'open3'

class Command
  def to_s
    "sacct -a"
  end

  JobInfo = Struct.new(:jobid, :jobname, :partition, :account, :cpus, :state, :exit_code)

  # Parse a string output from the `sacct` command and return an array of
  # JobInfo objects, one per lines
  def parse(output)
    lines = output.strip.split("\n").drop(2)
    lines.map do |line|
      JobInfo.new(*(line.split(" ", 7).collect(&:strip)))
    end
  end

  # Execute the command, and parse the output, returning and array of
  # JobInfo and nil for the error string.
  #
  # returns [Array<Array<JobInfo>, String] i.e.[info, error]
  def exec
    processes, error = [], nil

    stdout_str, stderr_str, status = Open3.capture3(to_s)
    if status.success?
      processes = parse(stdout_str)
    else
      error = "Command '#{to_s}' exited with error: #{stderr_str}"
    end

    [processes, error]
  end
end
