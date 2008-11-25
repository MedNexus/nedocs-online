# Try to lock the resource and execute passed block within context of lock
def try_lock(options = {})
  # Set default options
  lockfile_path = options[:lock_file]
  retries = options[:retries] || 1
  retry_period = options[:retry_period] || 0.5
  # Shared or exclusive lock?
  locking_method = options[:readonly_lock] ? File::LOCK_SH : File::LOCK_EX
  
  retries.times do |attempt|
    lockfile = File.open(lockfile_path, "a")
    locked = lockfile.flock(locking_method | File::LOCK_NB)
    if locked then
      begin
        lockfile.truncate(0)
        lockfile.puts(Process.pid)
        lockfile.flush
        retval = yield
        lockfile.close 
        File.unlink(lockfile_path)
        return retval
      rescue Exception => ex
        lockfile.close 
        raise ex
      end
    else
      lockfile.close rescue nil
      # Calculate exponential random backoff ala ethernet
      backoff_time = rand * retry_period * (2 ** attempt)
      STDERR.puts("Could not lock '#{lockfile_path}' (pid:#{Process.pid}) - " +
                  "#{attempt+1}/#{retries} (backing off " + 
                  "#{sprintf("%.2f", backoff_time)} seconds)")
      sleep(backoff_time)
    end
  end
  # If we get here, we're out of retries
  #raise "Locking Error" 
end
