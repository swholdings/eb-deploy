# arguments

pararser() {
    # Define default values
    appname=${appname:-"defaultApp"}
    region=${region:-"eu-west-1"}
    cfgtemplate=${cfgtemplate:-"elasticbeanstalk-whitelabel"}
    environment=${environment:-"master"}

    # Assign the values given by the user
    while [ $# -gt 0 ]; do
        if [[ $1 == *"--"* ]]; then
            param="${1/--/}"
            declare -g $param="$2"
        fi
        shift
    done

}
pararser $@

eb init --region eu-west-1 --platform "Docker running on 64bit Amazon Linux 2023" $appname --region $region
eb use $appname-$environment

# get s3 bucket for region
json_output=$(aws elasticbeanstalk describe-environment-resources --environment-name $appname-$environment --region $region)
instance=$(echo "$json_output" | jq -r '.EnvironmentResources.Instances[0].Id')

if [ ! -z "$instance" ]; then
    eb deploy