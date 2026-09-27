#!/usr/bin/env sh
DIR="$(cd "$(dirname "$0")" && pwd)"
CLASSPATH="$DIR/gradle/wrapper/gradle-wrapper.jar"

if [ ! -f "$CLASSPATH" ]; then
    echo "ERROR: gradle-wrapper.jar not found at $CLASSPATH" >&2
    echo "This is a binary Gradle generates itself. Install Gradle" >&2
    echo "(https://gradle.org/install/) then run 'gradle wrapper' once in" >&2
    echo "this folder, or just run 'gradle build' directly instead." >&2
    exit 1
fi

exec java -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
