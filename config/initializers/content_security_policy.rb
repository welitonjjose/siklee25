# # config/initializers/secure_headers.rb
# SecureHeaders::Configuration.default do |config|
#     config.hsts = "max-age=31536000; includeSubDomains; preload"
#     config.x_content_type_options = "nosniff"
#     config.x_frame_options = "SAMEORIGIN"
#     config.x_xss_protection = "1; mode=block"
#     config.referrer_policy = "strict-origin-when-cross-origin"
#     config.content_security_policy = {
#       default_src: "'self'",
#       script_src: ["'self'", "'unsafe-inline'"],
#       style_src: ["'self'", "'unsafe-inline'"],
#       img_src: ["'self'", "data:"],
#       connect_src: ["'self'"],
#       font_src: ["'self'"],
#       object_src: ["'none'"],
#       frame_ancestors: ["'none'"]
#     }
#   end
  