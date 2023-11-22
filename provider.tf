provider "proxmox" {
  pm_tls_insecure = true
  pm_timeout      = 360
  pm_log_enable   = false
  pm_debug        = false
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_otp          = ""
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}
