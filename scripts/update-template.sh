
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TEMPLATE_NAME=dagster-template
TEMPLATE_SRV="$(echo $TEMPLATE_NAME | tr '-' '_')"

echo
echo "Updating Dagster Template"
echo
echo "Renaming and Refactoring:"
echo "Repository: $REPO_NAME"
echo "Amazon Service Account: $REPO_NAME"
echo "Python Package: $PACKAGE_NAME"
echo

#workdir
cd ${SCRIPTPATH}/..

#rename folders
mv .platform/charts/$TEMPLATE_NAME .platform/charts/$REPO_NAME
mv $TEMPLATE_SRV $PACKAGE_NAME

#refactor files
repo_files=(".devcontainer/devcontainer.json",".devcontainer/docker-compose.yml",".platform/charts/$REPO_NAME/Chart.yaml" "docker/dagster/workspace.yaml" ".vscode/launch.json")
service_files=(".circleci/config.yml" "$PACKAGE_NAME/dagster/jobs/say_hello.py" "$PACKAGE_NAME/dagster/jobs/say_hello.py" "$PACKAGE_NAME/dagster/schedules/my_hourly_schedule.py" "$PACKAGE_NAME/dagster/sensors/my_sensor.py" "$PACKAGE_NAME/dagster/__init__.py" "docker/dagster/workspace.yaml" "tests/dagster/graphs/test_say_hello.py" "tests/dagster/ops/test_hello.py" "pyproject.toml")

for i in "${repo_files[@]}"
do
    sed -i "s|${TEMPLATE_NAME}|${REPO_NAME}|" $i
done
for i in "${service_files[@]}"
do
    sed -i "s|${TEMPLATE_SRV}|${PACKAGE_NAME}|" $i
done

echo
echo "To update your Python Package Dependencies with PDM, please run:"
echo "make pdm-lock"
echo
