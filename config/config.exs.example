# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :trot_cas, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:trot_cas, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :trot, :port, 4000
config :trot, :router, TrotCas.Router



config :ueberauth, Ueberauth,
  providers: [cas: {Ueberauth.Strategy.CAS, [
                       base_url: "http://118.6.16.9/cas/",
                       logout_url: "http://118.6.16.9/cas/logout",
                       callback: "http://202.111.111.11:4000/",
                     ]},
              inner_cas: {Ueberauth.Strategy.CAS, [
                             base_url: "http://192.168.190.100/cas/",
                             logout_url: "http://192.168.190.100/cas/logout",
                             callback: "http://172.16.100.100:4000/",
                           ]},
              inner_net: ["192.168.0.0/16",
                          "172.16.0.0/16"]
             ]


# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
