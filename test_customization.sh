#!/bin/bash

# This script tests the customization process by customizing and then resetting using git

set -e

echo "Testing Customization Process"
echo "============================"

# First, make sure we have a clean state
echo "Ensuring clean git state..."
git checkout -- pom.xml README.adoc SECURITY.md .github/project.yml src/site/site.xml src/main/java/module-info.java

# Backup the original customization.properties
if [ -f "customization.properties" ]; then
    cp customization.properties customization.properties.bak
fi

# Create a test customization.properties with new values
echo "Creating test customization properties..."
cat > customization.properties << 'ENDPROPS'
# Project customization properties

# Used in pom.xml (artifactId), README.adoc (badges), .github/project.yml (name, pages-reference) src/site/site.xml (links), SECURITY.md (links)
project.key=test-java-module

# Used in pom.xml (<n> tag)
project.name=Test Java Module

# Used in pom.xml (<description> tag)
project.description=This is a test module for testing customization.

# Used in pom.xml (property maven.jar.plugin.automatic.module.name)
project.moduleName=de.cuioss.test

# Used in pom.xml (groupId, README.adoc (badges))
project.groupId=de.cuioss

# Derived properties (do not edit directly)
project.scm.url=https://github.com/cuioss/${project.key}/
project.pages.url=https://cuioss.github.io/${project.key}/
project.sonar.id=cuioss_${project.key}
ENDPROPS

# Run the customization (use echo to avoid the need for user input)
echo "Running customization with test values..."
echo "" | ./customize.sh

# Check if customization worked
echo "Verifying customization..."
if grep -q "test-java-module" pom.xml && grep -q "test-java-module" README.adoc; then
    echo "✅ Customization successful!"
else
    echo "❌ Customization failed!"
    exit 1
fi

# Reset to original state
echo "Resetting to original state..."
git checkout -- pom.xml README.adoc SECURITY.md .github/project.yml src/site/site.xml src/main/java/module-info.java

# Verify reset
echo "Verifying reset..."
if grep -q "cui-java-module-template" pom.xml && grep -q "cui-java-module-template" README.adoc; then
    echo "✅ Reset successful!"
else
    echo "❌ Reset failed!"
    exit 1
fi

# Restore original customization.properties if it existed
if [ -f "customization.properties.bak" ]; then
    mv customization.properties.bak customization.properties
fi

echo ""
echo "✅ Test completed successfully! The customization process works as expected."
echo "The script can successfully customize the project and be reset using git."
