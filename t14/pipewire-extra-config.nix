{
  pipewire = {
    "equalizer" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "equalizer";
            "media.name"       = "equalizer";
            "filter.graph" = {
              nodes = [
                { name = "eqFL"; type="builtin"; label="bq_peaking"; control = { Freq=24; Q=0.5; Gain=15; }; }
                { name = "eqFR"; type="builtin"; label="bq_peaking"; control = { Freq=24; Q=0.5; Gain=15; }; }
                { name = "eqFL2"; type="builtin"; label="bq_peaking"; control = { Freq=4000; Q=0.7; Gain=-6; }; }
                { name = "eqFR2"; type="builtin"; label="bq_peaking"; control = { Freq=4000; Q=0.7; Gain=-6; }; }
              ];
              links = [
                { output="eqFL:Out"; input="eqFL2:In"; }
                { output="eqFR:Out"; input="eqFR2:In"; }
              ];
              inputs = [ "eqFL:In" "eqFR:In" ];
              outputs = [ "eqFL2:Out" "eqFR2:Out" ];
            };
            "capture.props" = {
              "node.name" = "effect_input.equalizer";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
            "playback.props" = {
              "node.name" = "effect_output.equalizer";
              "node.passive" = true;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
  };
}
