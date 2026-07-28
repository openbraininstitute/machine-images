libsonata_commit         = "v0.1.37"
libsonatareport_commit   = "de0abd0e73f29975ec7caeb80118bd617f2dbe0c"
neurodamus_commit        = "4.2.4"
neuron_commit            = "2ac5cc7191e44805cdf40abf0ad6d3fac1481d49"
python_version           = "3.12"
uv_version               = "0.11.15"
neurodamus_script_commit = "77f9250f8db7f307e518ee7d3da66083c2a6ca71"

ami_share_accounts = ["671250183987"] # production

# the AMI build has to happen on a machine that supports EFA
aws_instance_type = "c5n.9xlarge"

az_region = "South Central US"
az_instance_type = "Standard_E4s_v3"
az_resource_group = "obi-batch-rg"
