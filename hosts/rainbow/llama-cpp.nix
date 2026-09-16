{ pkgs, config, ... }:
{

  sops.secrets."llama-cpp/OPENAI_API_KEY" = {
    mode = "0444";
  };

  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.unstable.llama-cpp-rocm;
    extraFlags = [ "--load-mode" "none" "--models-max" "1" "--api-key-file" "${toString config.sops.secrets."llama-cpp/OPENAI_API_KEY".path}" ];

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
      "qwen3.8-27b" = {
        hf-repo = "unsloth/Qwen3.8-27B-GGUF";
        hf-file = "Qwen3.8-27B-UD-Q3_K_XL.gguf";
        alias = "qwen3.8-27b";

        n-gpu-layers = "99";
        ctx-size = "32768"; # raise until it OOMs, 262144 is the model max
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        batch-size = "512";
        ubatch-size = "256";
        parallel = "1";
        no-mmproj = "true"; # skips the 931 MB vision projector

        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "0.0";
        repeat-penalty = "1.0";
      };
      # Same GGUF, non-thinking sampling. Costs no extra disk.
      "qwen3.8-27b-instruct" = {
        hf-repo = "unsloth/Qwen3.8-27B-GGUF";
        hf-file = "Qwen3.8-27B-UD-Q3_K_XL.gguf";
        alias = "qwen3.8-27b-instruct";

        n-gpu-layers = "99";
        ctx-size = "32768";
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        parallel = "1";
        no-mmproj = "true";
        reasoning = "off";

        temp = "0.7";
        top-p = "0.80";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";
      };
      "Qwen3-VL-8B-Instruct" = {
        hf-repo = "unsloth/Qwen3-VL-8B-Instruct-GGUF";
        hf-file = "Qwen3-VL-8B-Instruct-UD-Q6_K_XL.gguf"; # ~7GB weights, leaves room to spare
        alias = "qwen3-vl-8b-instruct";
        # mmproj (vision tower) is auto-downloaded from the same repo when using hf-repo

        # Qwen's official "Instruct" (non-thinking) sampling recipe
        temp = "0.7";
        top-p = "0.8";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "1.5";
        repeat-penalty = "1.0";

        # 16GB VRAM, full offload
        n-gpu-layers = "99"; # every layer + vision encoder on GPU
        ctx-size = "32768"; # images eat context fast; this leaves headroom
        flash-attn = "on"; # required to use the quantized KV cache below
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        jinja = "true"; # required for Qwen3-VL's chat template
      };
    };
  };
};

systemd.services.llama-cpp.environment.HSA_OVERRIDE_GFX_VERSION = "11.0.0";

# The service runs under DynamicUser, so it has no access to /dev/dri
# without this. Also works around the Mesa shader cache issue (#441531).
systemd.services.llama-cpp.serviceConfig.SupplementaryGroups = [ "render" "video" ];
systemd.services.llama-cpp.environment = {
XDG_CACHE_HOME = "/var/cache/llama-cpp";
MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
};

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
