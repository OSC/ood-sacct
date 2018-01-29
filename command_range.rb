require 'open3'

class CommandRange

  # @param [string] start_datetime The start time in format: 2017-12-11T16:00
  # @param [string] end_datetime The end time in format: 2017-12-11T16:00
  def initialize(start_datetime, end_datetime)
    # This command is specific to PSC
    @command = "/opt/packages/slurm/17.02.5/bin/sacct -a --starttime #{start_datetime} --endtime #{end_datetime} --format=User,JobID,Jobname,start,end,state -P -s BF,CA,CD,DL,F,NF,PR,TO"
  end

  def to_s
    @command
  end

  JobInfo = Struct.new(:user, :jobid, :jobname, :start, :end, :state)

  # Parse a string output from the `sacct` command and return an array of
  # JobInfo objects, one per lines
  def parse(output)
    lines = output.strip.split("\n").drop(1)
    lines.map do |line|
      JobInfo.new(*(line.split("|", 6)))
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

  rescue => e
    [processes, e.message]
  end
end
