libsonata_commit         = "v0.2.2"
libsonatareport_commit   = "2.0.0"
neurodamus_commit        = "4.2.7"
neuron_commit            = "2ac5cc7191e44805cdf40abf0ad6d3fac1481d49"
neuron_version           = "9.0.0"
python_version           = "3.12"
uv_version               = "0.11.15"
neurodamus_script_commit = "4.2.7"
h5py_version             = "3.16.0"

ami_share_accounts = ["671250183987"] # production

# the AMI build has to happen on a machine that supports EFA
aws_instance_type = "c5n.9xlarge"

az_instance_type = "Standard_E4s_v3"
az_build_resource_group_name = "auto-machine-images-rg"
az_gallery_name = "openbraininstitute_image_gallery"
