# With thanks to @myronmarston
# https://github.com/vcr/vcr/blob/master/spec/capture_warnings.rb

module CaptureWarnings
  def report_warnings(&block)
    current_dir = Dir.pwd
    warnings, errors = capture_error(&block).partition { |line| line.include?('warning') }
    project_warnings, other_warnings = warnings.uniq.partition { |line| line.include?(current_dir) }

    if errors.any?
      puts errors.join("\n")
    end

    if other_warnings.any?
      puts "#{ other_warnings.count } non-cucumber-core warnings detected, set VIEW_OTHER_WARNINGS=true to see them."
      print_warnings('other', other_warnings) if ENV['VIEW_OTHER_WARNINGS']
    end

    if project_warnings.any?
      puts "#{ project_warnings.count } cucumber-core warnings detected" 
      print_warnings('cucumber-core', project_warnings)
      fail "Please remove all cucumber-core warnings."
    end
  end

  def capture_error(&block)
    old_stderr = STDERR.clone
    pipe_r, pipe_w = IO.pipe
    pipe_r.sync    = true
    error         = ""
    reader = Thread.new do
      begin
        loop do
          error << pipe_r.readpartial(1024)
        end
      rescue EOFError
      end
    end
    STDERR.reopen(pipe_w)
    block.call
  ensure
    STDERR.reopen(old_stderr)
    pipe_w.close
    reader.join
    return error.split("\n")
  end

  def print_warnings(type, warnings)
    puts
    puts "-" * 30 + " #{type} warnings: " + "-" * 30
    puts
    puts warnings.join("\n")
    puts
    puts "-" * 75
    puts
  end
end
