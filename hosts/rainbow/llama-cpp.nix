{ pkgs, config, ... }:
{

  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.unstable.llama-cpp-rocm;
    extraFlags = [ "--load-mode" "none" ];
    modelsPreset = {
      "qwen3.6-35b-a3b" = {
        hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF";
        hf-file = "Qwen3.6-35B-A3B-UD-IQ4_NL.gguf"; # ~18 GB on disk
        alias = "qwen3.6-35b-a3b";

        # For a MoE model, -ngl is no longer your VRAM dial: keep it maxed
        # so attention/shared tensors for all 40 layers land on the GPU.
        n-gpu-layers = "999";

        # ...and use this instead: pin the first 24 of 40 layers' *expert*
        # FFN weights to system RAM, everything else stays on the card.
        # Rough sizing for UD-IQ4_NL (~18 GB, ~90% of that is expert
        # weight spread over 40 layers, ~0.4 GB/layer): 24 layers moved
        # off ≈ 9 GB freed, leaving ~8-9 GB of weights resident plus
        # headroom for KV cache, compute buffers, and GNOME's own VRAM
        # use on this box. Starting point, not a measured optimum — sweep
        # below.
        n-cpu-moe = "24";

        # Hand-tuning the two flags above, so don't let auto-fit override them.
        fit = "off";

        ctx-size = "32768";
        batch-size = "1024";
        ubatch-size = "256";
        flash-attn = "on";

        jinja = "on"; # required for Qwen3.6's chat template + tool calling

        # Qwen3.6's own recommended sampler settings, "thinking mode,
        # general tasks" (it thinks by default, unlike plain Qwen3):
        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
      };
    };
  };

  systemd.services.llama-cpp.environment.HSA_OVERRIDE_GFX_VERSION = "11.0.1";

  services.nginx = {
    virtualHosts = {
      "ai.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://${toString config.services.llama-cpp.host}:${toString config.services.llama-cpp.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

}
