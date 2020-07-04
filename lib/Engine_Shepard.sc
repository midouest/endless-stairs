Engine_Shepard : CroneEngine {
  var voices;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef("Shepard", {
      arg out;

      var freq = \freq.kr(0),
          level = \level.kr(0),
          trig = \trig.tr(0),
          decay = \decay.kr(0.5),
          drone = \drone.kr(0),
          pan = \pan.kr(0);

      var osc = SinOsc.ar(freq);

      var env = EnvGen.kr(Env.perc(releaseTime: decay, level: level), trig);
      var amp = Select.kr(drone, [env, level]);

      Out.ar(out, Pan2.ar(osc * amp, pan));
    }).add;

    context.server.sync;

    voices = Array.fill(6, { Synth.new("Shepard") });

    this.addCommand(\play_voice, "iff", { |msg|
      var voice = voices[msg[1]];
      voice.set(\freq, msg[2]);
      voice.set(\level, msg[3]);
      voice.set(\trig, 1);
    });

    this.addCommand(\set_drone, "i", { |msg|
      voices.do({ arg voice;
        voice.set(\drone, msg[1]);
      });
    });

    this.addCommand(\set_decay, "f", { |msg|
      voices.do({ arg voice;
        voice.set(\decay, msg[1]);
      });
    });

    this.addCommand(\set_pan, "if", { |msg|
      var voice = voices[msg[1]];
      voice.set(\pan, msg[2]);
    });
  }

  free {
    voices.do({ arg voice; voice.free });
  }
}
