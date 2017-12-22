require 'open3'

class Command
  def to_s
    # This command is specific to PSC
    "/opt/packages/slurm/17.02.5/bin/sacct -a"
  end

  JobInfo = Struct.new(:jobid, :jobname, :partition, :account, :cpus, :state, :exit_code)

  # Parse a string output from the `sacct` command and return an array of
  # JobInfo objects, one per lines
  def parse(output)
    column_lengths = output.strip.split("\n")[1].split.map {|x| x = x.length}
    lines = output.strip.split("\n").drop(2)
    lines.map do |line|
      jobinfo_args = []
      column_lengths.each do |length|
        jobinfo_args.push(line.slice!(0..length).strip)
      end
      JobInfo.new(*jobinfo_args)
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
