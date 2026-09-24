#!/bin/bash

set -e

echo "Project Customization Script"
echo "============================"

# Check if the customization.properties file exists
if [ ! -f "customization.properties" ]; then
    echo "Error: customization.properties file not found."
    exit 1
fi

# Function to read property from file
function get_prop {
    grep "^$1=" customization.properties | cut -d'=' -f2-
}

# Read properties
PROJECT_KEY=$(get_prop "project.key")
PROJECT_NAME=$(get_prop "project.name")
PROJECT_DESCRIPTION=$(get_prop "project.description")
PROJECT_MODULE_NAME=$(get_prop "project.moduleName")
PROJECT_GROUP_ID=$(get_prop "project.groupId")
PROJECT_INCEPTION_YEAR=$(get_prop "project.inceptionYear")
# A stale inception year restamps every source header on every build, so an
# unset value defaults to now rather than inheriting the template's 2023.
: "${PROJECT_INCEPTION_YEAR:=$(date +%Y)}"

# Derive additional properties
PROJECT_SCM_URL="https://github.com/cuioss/${PROJECT_KEY}/"
PROJECT_PAGES_URL="https://cuioss.github.io/${PROJECT_KEY}/"
PROJECT_SONAR_ID="cuioss_${PROJECT_KEY}"

echo "Applying customizations with the following values:"
echo " - Project Key: $PROJECT_KEY"
echo " - Project Name: $PROJECT_NAME"
echo " - Project Description: $PROJECT_DESCRIPTION"
echo " - Module Name: $PROJECT_MODULE_NAME"
echo " - Group ID: $PROJECT_GROUP_ID"
echo " - Inception Year: $PROJECT_INCEPTION_YEAR"
echo " - SCM URL: $PROJECT_SCM_URL"
echo " - Pages URL: $PROJECT_PAGES_URL"
echo " - Sonar ID: $PROJECT_SONAR_ID"
echo ""
echo "Press ENTER to continue or CTRL+C to abort..."
read

echo "Customizing project files..."

# Function to replace text in files using sed
replace_in_file() {
    local file=$1
    local search=$2
    local replace=$3
    
    if [ -f "$file" ]; then
        # Different sed syntax for different operating systems
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # MacOS requires an empty string after -i
            sed -i '' "s#${search}#${replace}#g" "$file"
        else
            # Linux
            sed -i "s#${search}#${replace}#g" "$file"
        fi
        echo "Updated: $file"
    else
        echo "Warning: File $file not found, skipping."
    fi
}

# Update pom.xml
replace_in_file "pom.xml" "<artifactId>cui-java-module-template</artifactId>" "<artifactId>${PROJECT_KEY}</artifactId>"
replace_in_file "pom.xml" "<name>cui java module template</name>" "<name>${PROJECT_NAME}</name>"
replace_in_file "pom.xml" "<description>Template module for cuioss open source projects." "<description>${PROJECT_DESCRIPTION}"
replace_in_file "pom.xml" "<inceptionYear>2023</inceptionYear>" "<inceptionYear>${PROJECT_INCEPTION_YEAR}</inceptionYear>"
replace_in_file "pom.xml" "<maven.jar.plugin.automatic.module.name>de.cuioss.template</maven.jar.plugin.automatic.module.name>" "<maven.jar.plugin.automatic.module.name>${PROJECT_MODULE_NAME}</maven.jar.plugin.automatic.module.name>"
replace_in_file "pom.xml" "<url>https://github.com/cuioss/cui-java-module-template/</url>" "<url>${PROJECT_SCM_URL}</url>"
replace_in_file "pom.xml" "<url>https://github.com/cuioss/cui-java-module-template/issues</url>" "<url>${PROJECT_SCM_URL}issues</url>"
replace_in_file "pom.xml" "scm:git:https://github.com/cuioss/cui-java-module-template.git" "scm:git:${PROJECT_SCM_URL}.git"
replace_in_file "pom.xml" "scm:git:https://github.com/cuioss/cui-java-module-template/" "scm:git:${PROJECT_SCM_URL}"

# Update README.adoc
replace_in_file "README.adoc" "= cui-java-module-template" "= ${PROJECT_KEY}"
replace_in_file "README.adoc" "cuioss/cui-java-module-template" "cuioss/${PROJECT_KEY}"
replace_in_file "README.adoc" "de.cuioss/cui-java-module-template" "${PROJECT_GROUP_ID}/${PROJECT_KEY}"
# Fix for Maven Central badge - update the groupId in the badge URL
replace_in_file "README.adoc" "maven-central/v/de.cuioss/" "maven-central/v/${PROJECT_GROUP_ID}/"
# Fix for Maven Central artifact link
replace_in_file "README.adoc" "central.sonatype.com/artifact/de.cuioss/" "central.sonatype.com/artifact/${PROJECT_GROUP_ID}/"
replace_in_file "README.adoc" "cuioss_cui-java-module-template" "${PROJECT_SONAR_ID}"

# Update .github/project.yml
# Only name, description, sonar and pages keys. NEVER release.current-version: merging a change of
# it is a Maven Central release (see the comment in .github/project.yml).
replace_in_file ".github/project.yml" "^name: cui-java-module-template$" "name: ${PROJECT_KEY}"
replace_in_file ".github/project.yml" "^description: Template for cuioss Java modules$" "description: ${PROJECT_DESCRIPTION}"
replace_in_file ".github/project.yml" "project-key: cuioss_cui-java-module-template" "project-key: ${PROJECT_SONAR_ID}"
replace_in_file ".github/project.yml" "reference: cui-java-module-template" "reference: ${PROJECT_KEY}"

# Update CLAUDE.md and the release runbook (repository slug only).
# .github/workflows/release.yml is deliberately NOT touched: its template-repository exclusion must
# keep naming cuioss/cui-java-module-template, otherwise the new repository could never release.
replace_in_file "CLAUDE.md" "cuioss/cui-java-module-template" "cuioss/${PROJECT_KEY}"
# Only the `--repo` arguments: the template-exclusion literal quoted in the runbook must stay.
replace_in_file ".claude/skills/release/SKILL.md" "repo cuioss/cui-java-module-template" "repo cuioss/${PROJECT_KEY}"

# Update site.xml
replace_in_file "src/site/site.xml" "https://github.com/cuioss/cui-java-module-template" "${PROJECT_SCM_URL}"

# Update module-info.java if module name changed
if [ "${PROJECT_MODULE_NAME}" != "de.cuioss.template" ]; then
    replace_in_file "src/main/java/module-info.java" "module de.cuioss.template" "module ${PROJECT_MODULE_NAME}"
    # The exported package stays de.cuioss.template until you move the sources; rename both together.
fi

echo "Customization completed successfully!"
echo ""
echo "Next steps (see README.adoc, 'After creating the repository'):"
echo " - Do NOT change release.current-version in .github/project.yml: merging that change IS a release."
echo " - SonarCloud: create ${PROJECT_SONAR_ID} and rename its main branch 'master' to 'main' before the first analysis."
echo " - Add ${PROJECT_KEY} to 'consumers:' in cuioss-organization/.github/project.yml."
echo " - Apply branch protection / merge queue with cuioss-organization/branch-protection."
echo ""
echo "To reset to original values, you can use Git to revert changes:"
echo "  git checkout -- pom.xml README.adoc CLAUDE.md .claude/skills/release/SKILL.md .github/project.yml src/site/site.xml src/main/java/module-info.java"
echo "And then run this script again with the desired values in customization.properties."
