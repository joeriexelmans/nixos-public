{
  pipewire = {
    "10-downmix-5.1-to-4.0" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "5.1 surround downmix";
            "media.name"       = "5.1 surround downmix";
            "filter.graph" = {
              nodes = builtins.concatLists [
                # FC and LFE connect to multiple nodes, so we need to create a 'copy' node for them
                (map (name: { name=name; type="builtin"; label="copy"; })
                  [ "copyFC" "copyLFE" ])

                # Each output (FL, FR, RL, RR) is mixed from:
                #  In 1: their respective inputs (at original level)
                #  In 2: the center channel (only for FL and FR)
                #  In 3: the LFE channel (already amplified to match other channels by the decoder (e.g., 10 dB in Dolby spec) divided by 4)
                (map (name: { name=name; type="builtin"; label="mixer"; control={"Gain 1"=1; "Gain 2"=0.5; "Gain 3"=0.25;}; })
                  [ "mixFL" "mixFR" "mixRL" "mixRR" ])
              ];
              links = [
                # FC goes into FL and FR (at half gain)
                { output = "copyFC:Out"; input = "mixFL:In 2"; }
                { output = "copyFC:Out"; input = "mixFR:In 2"; }

                # LFE goes into all 4 channels
                { output = "copyLFE:Out"; input = "mixFL:In 3"; }
                { output = "copyLFE:Out"; input = "mixFR:In 3"; }
                { output = "copyLFE:Out"; input = "mixRL:In 3"; }
                { output = "copyLFE:Out"; input = "mixRR:In 3"; }
              ];
              inputs = [ "mixFL:In 1" "mixFR:In 1" "copyFC:In" "copyLFE:In" "mixRL:In 1" "mixRR:In 1" ];
              outputs = [ "mixFL:Out" "mixFR:Out" "mixRL:Out" "mixRR:Out" ];
            };
            "capture.props" = {
              "node.name"      = "effect_input.downmix-5.1-to-4.0";
              "media.class"    = "Audio/Sink";
              "audio.channels" = 6;
              "audio.position" = [ "FL" "FR" "FC" "LFE" "RL" "RR" ];
            };
            "playback.props" = {
              "node.name"      = "effect_output.downmix-5.1-to-4.0";
              "node.passive"   = true;
              "audio.channels" = 4;
              "audio.position" = [ "FL" "FR" "RL" "RR" ];
            };
          };
        }
      ];
    };
    # The following filter is meant for a quadrophonics (4.0) setup with 4 full-range speakers and no dedicated subwoofer.
    # It extracts bass from all 4 channels, mixes it, and feeds it back equally to all channels (bass becomes mono).
    # The result is more flat bass response in much of the room.
    "20-subwoofer-crossover" = let
      crossoverFreq = 60;
    in {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Subwoofer crossover";
            "media.name"       = "Subwoofer crossover";
            "filter.graph" = {
              nodes = builtins.concatLists [
                # Create copy nodes for all our inputs
                (map (name: { name=name; type="builtin"; label="copy"; })
                  [ "copyFL" "copyFR" "copyRL" "copyRR" ])

                # Each channel is high-passed
                (map (name: { name=name; type="builtin"; label="bq_highpass"; })
                  [ "highpassFL" "highpassFR" "highpassRL" "highpassRR" ])

                # Create our 'LFE' channel
                # All channels are mixed before being low-passed (for subwoofer channel)
                [
                  {
                    name = "mixAll";
                    type = "builtin";
                    label = "mixer";
                    control = { "Gain 1"=0.25; "Gain 2"=0.25; "Gain 3"=0.25; "Gain 4"=0.25; };
                  }
                  {
                    name = "lowpass";
                    type = "builtin";
                    label = "bq_lowpass";
                    control = { Freq = crossoverFreq; };
                  }
                  # While we're at it, let's add some extra "oomph"
                  {
                    name = "oomph";
                    type = "builtin";
                    label = "bq_peaking";
                    control = { Freq = 28; Q = 1; Gain = 6; };
                  }
                ]

                # Each of the 4 resulting outputs is mixed from (1) the high-passed channel, (2) the low-passed mix of all 4 channels
                (map (name: { name=name; type="builtin"; label="mixer"; })
                  [ "mixFL" "mixFR" "mixRL" "mixRR" ])
              ];
              links = [
                # All 4 channels are mixed to extract subwoofer channel
                { output = "copyFL:Out"; input = "mixAll:In 1"; }
                { output = "copyFR:Out"; input = "mixAll:In 2"; }
                { output = "copyRL:Out"; input = "mixAll:In 3"; }
                { output = "copyRR:Out"; input = "mixAll:In 4"; }

                # All 4 channels are high-passed
                { output = "copyFL:Out"; input = "highpassFL:In"; }
                { output = "copyFR:Out"; input = "highpassFR:In"; }
                { output = "copyRL:Out"; input = "highpassRL:In"; }
                { output = "copyRR:Out"; input = "highpassRR:In"; }

                # The mixed channel is low-passed
                { output = "mixAll:Out"; input = "lowpass:In"; }
                { output = "lowpass:Out"; input = "oomph:In"; }

                # The low-passed signal is mixed into every output channel
                { output = "oomph:Out"; input = "mixFL:In 1"; }
                { output = "oomph:Out"; input = "mixFR:In 1"; }
                { output = "oomph:Out"; input = "mixRL:In 1"; }
                { output = "oomph:Out"; input = "mixRR:In 1"; }

                # The high-passed signals are mixed into their respective output channels
                { output = "highpassFL:Out"; input = "mixFL:In 2"; }
                { output = "highpassFR:Out"; input = "mixFR:In 2"; }
                { output = "highpassRL:Out"; input = "mixRL:In 2"; }
                { output = "highpassRR:Out"; input = "mixRR:In 2"; }
              ];
              inputs = [ "copyFL:In" "copyFR:In" "copyRL:In" "copyRR:In" ];
              outputs = [ "mixFL:Out" "mixFR:Out" "mixRL:Out" "mixRR:Out" ];
            };
            "capture.props" = {
              "node.name"      = "effect_input.subwoofer-crossover";
              "media.class"    = "Audio/Sink";
              "audio.channels" = 4;
              "audio.position" = [ "FL" "FR" "RL" "RR" ];
            };
            "playback.props" = {
              "node.name"      = "effect_output.subwoofer-crossover";
              "node.passive"   = true;
              "audio.channels" = 4;
              "audio.position" = [ "FL" "FR" "RL" "RR" ];
            };
          };
        }
      ];
    };
    # Upmixes stereo (2.0) to quadrophonics (4.0).
    # The rear speakers get the signal from the front speakers, rotated by 90 degrees, and slightly delayed.
    "30-upmix-2.0-to-4.0" = let
      #delay = 0.000; # (ms) delay of rear speakers
      delay = 0.009; # (ms) delay of rear speakers
    in {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Upmix 2.0 -> 4.0";
            "media.name"       = "Upmix 2.0 -> 4.0";
            "filter.graph" = {
              nodes = builtins.concatLists [
                (map (name: { name=name; type="builtin"; label="copy"; })
                  [ "copyFL" "copyFR" "outFL" "outFR" ])

                (map (name: { name=name; type="builtin"; label="convolver"; config={filename="/hilbert";}; })
                  [ "rotateL" "rotateR" ])

                (map (name: { name=name; type="builtin"; label="delay"; control={"Delay (s)"=delay;}; config={max-delay=delay;}; })
                  [ "delayL" "delayR" ])
              ];
              links = [
                # Front channels
                { output = "copyFL:Out";  input = "outFL:In"; }
                { output = "copyFR:Out";  input = "outFR:In"; }
                # Rear channels
                { output = "copyFL:Out";  input = "rotateL:In"; }
                { output = "copyFR:Out";  input = "rotateR:In"; }
                { output = "rotateL:Out";  input = "delayL:In"; }
                { output = "rotateR:Out";  input = "delayR:In"; }
              ];
              inputs = [ "copyFL:In" "copyFR:In" ];
              outputs = [ "outFL:Out" "outFR:Out" "delayL:Out" "delayR:Out" ];
            };
            "capture.props" = {
              "node.name" = "effect_input.upmix-2.0-to-4.0";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
            "playback.props" = {
              "node.name" = "effect_output.upmix-2.0-to-4.0";
              "node.passive" = true;
              "audio.channels" = 4;
              "audio.position" = [ "FL" "FR" "RL" "RR" ];
            };
          };
        }
      ];
    };
  };
}