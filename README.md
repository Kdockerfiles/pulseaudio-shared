**[PulseAudio shared files for Alpine-based Docker containers](https://hub.docker.com/r/kdockerfiles/pulseaudio-shared/)**

# Usage

It should generally not be run directly, instead it can be used as a basis for either providing a PulseAudio server or for dockerizing applications that depend on PulseAudio.

It is literally just a plain Alpine image with PulseAudio artifacts stored in `/usr/local/`.

For example usages see [Kdockerfiles/pulseaudio](https://github.com/Kdockerfiles/pulseaudio) and [Kdockerfiles/mpd](https://github.com/Kdockerfiles/mpd).

# Limitations

It is currently compiled *without* udev support, because I couldn't get PA's udev module to work inside Docker. Suggestions (better yet, PRs) welcome.
