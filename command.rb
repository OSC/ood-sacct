require 'open3'

class Command
  attr_accessor :jobid

  def to_s
    # This command is specific to PSC
    "/opt/packages/slurm/17.02.5/bin/sacct --long -P -j #{jobid}"
  end

  def initialize(jobid)
    @jobid = jobid
  end

  JobInfo = Struct.new(:JobID, :JobIDRaw, :JobName, :Partition, :MaxVMSize, :MaxVMSizeNode, :MaxVMSizeTask, :AveVMSize, :MaxRSS, :MaxRSSNode, :MaxRSSTask, :AveRSS, :MaxPages, :MaxPagesNode, :MaxPagesTask, :AvePages, :MinCPU, :MinCPUNode, :MinCPUTask, :AveCPU, :NTasks, :AllocCPUS, :Elapsed, :State, :ExitCode, :AveCPUFreq, :ReqCPUFreqMin, :ReqCPUFreqMax, :ReqCPUFreqGov, :ReqMem, :ConsumedEnergy, :MaxDiskRead, :MaxDiskReadNode, :MaxDiskReadTask, :AveDiskRead, :MaxDiskWrite, :MaxDiskWriteNode, :MaxDiskWriteTask, :AveDiskWrite, :AllocGRES, :ReqGRES, :ReqTRES, :AllocTRES )

  def parse(output)
    lines = output.strip.split("\n").drop(1)
    lines.map do |line|
      JobInfo.new(*(line.split("|", 43)))
    end
  end

  # Execute the command, and parse the output, returning and array of
  # JobInfo and nil for the error string.
  #
  # returns [Array<Array<JobInfo>, String] i.e.[info, error]
  def exec
    output, error = "", nil

    stdout_str, stderr_str, status = Open3.capture3(to_s)
    if status.success?
      output = parse(stdout_str)
    else
      error = "Command '#{to_s}' exited with error: #{stderr_str}"
    end

    [output, error]
  rescue => e
    [output, e.message]
  end
end
