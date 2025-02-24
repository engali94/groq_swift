//
//  GroqModel.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import Foundation

enum GroqModel: String, CaseIterable, Identifiable {
    // Production Models
    case distilWhisperLargeV3En = "distil-whisper-large-v3-en"
    case gemma2_9b_it = "gemma2-9b-it"
    case llama_3_3_70b_versatile = "llama-3.3-70b-versatile"
    case llama_3_1_8b_instant = "llama-3.1-8b-instant"
    case llama_guard_3_8b = "llama-guard-3-8b"
    case llama3_70b_8192 = "llama3-70b-8192"
    case llama3_8b_8192 = "llama3-8b-8192"
    case mixtral_8x7b_32768 = "mixtral-8x7b-32768"
    case whisper_large_v3 = "whisper-large-v3"
    case whisper_large_v3_turbo = "whisper-large-v3-turbo"

    // Preview Models
    case qwen_2_5_coder_32b = "qwen-2.5-coder-32b"
    case qwen_2_5_32b = "qwen-2.5-32b"
    case deepseek_r1_distill_qwen_32b = "deepseek-r1-distill-qwen-32b"
    case deepseek_r1_distill_llama_70b_specdec = "deepseek-r1-distill-llama-70b-specdec"
    case deepseek_r1_distill_llama_70b = "deepseek-r1-distill-llama-70b"
    case llama_3_3_70b_specdec = "llama-3.3-70b-specdec"
    case llama_3_2_1b_preview = "llama-3.2-1b-preview"
    case llama_3_2_3b_preview = "llama-3.2-3b-preview"
    case llama_3_2_11b_vision_preview = "llama-3.2-11b-vision-preview"
    case llama_3_2_90b_vision_preview = "llama-3.2-90b-vision-preview"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .distilWhisperLargeV3En: return "Distil Whisper Large V3 (EN)"
        case .gemma2_9b_it: return "Gemma 2 9B"
        case .llama_3_3_70b_versatile: return "LLaMA 3.3 70B Versatile"
        case .llama_3_1_8b_instant: return "LLaMA 3.1 8B Instant"
        case .llama_guard_3_8b: return "LLaMA Guard 3 8B"
        case .llama3_70b_8192: return "LLaMA 3 70B"
        case .llama3_8b_8192: return "LLaMA 3 8B"
        case .mixtral_8x7b_32768: return "Mixtral 8x7B"
        case .whisper_large_v3: return "Whisper Large V3"
        case .whisper_large_v3_turbo: return "Whisper Large V3 Turbo"
        case .qwen_2_5_coder_32b: return "Qwen 2.5 Coder 32B"
        case .qwen_2_5_32b: return "Qwen 2.5 32B"
        case .deepseek_r1_distill_qwen_32b: return "DeepSeek R1 Distill Qwen 32B"
        case .deepseek_r1_distill_llama_70b_specdec: return "DeepSeek R1 Distill LLaMA 70B SpecDec"
        case .deepseek_r1_distill_llama_70b: return "DeepSeek R1 Distill LLaMA 70B"
        case .llama_3_3_70b_specdec: return "LLaMA 3.3 70B SpecDec"
        case .llama_3_2_1b_preview: return "LLaMA 3.2 1B Preview"
        case .llama_3_2_3b_preview: return "LLaMA 3.2 3B Preview"
        case .llama_3_2_11b_vision_preview: return "LLaMA 3.2 11B Vision Preview"
        case .llama_3_2_90b_vision_preview: return "LLaMA 3.2 90B Vision Preview"
        }
    }

    var icon: String {
        switch self {
        case .distilWhisperLargeV3En, .whisper_large_v3, .whisper_large_v3_turbo:
            return "waveform"
        case .llama_3_2_11b_vision_preview, .llama_3_2_90b_vision_preview:
            return "eye"
        case .qwen_2_5_coder_32b:
            return "chevron.left.forwardslash.chevron.right"
        default:
            return "cpu.fill"
        }
    }

    var isPreview: Bool {
        switch self {
        case .qwen_2_5_coder_32b, .qwen_2_5_32b,
             .deepseek_r1_distill_qwen_32b, .deepseek_r1_distill_llama_70b_specdec,
             .deepseek_r1_distill_llama_70b, .llama_3_3_70b_specdec,
             .llama_3_2_1b_preview, .llama_3_2_3b_preview,
             .llama_3_2_11b_vision_preview, .llama_3_2_90b_vision_preview:
            return true
        default:
            return false
        }
    }

    var contextWindow: Int? {
        switch self {
        case .gemma2_9b_it, .llama_guard_3_8b,
             .llama3_70b_8192, .llama3_8b_8192,
             .llama_3_3_70b_specdec:
            return 8_192
        case .mixtral_8x7b_32768:
            return 32_768
        case .llama_3_3_70b_versatile, .llama_3_1_8b_instant,
             .qwen_2_5_coder_32b, .qwen_2_5_32b,
             .deepseek_r1_distill_qwen_32b, .deepseek_r1_distill_llama_70b_specdec,
             .deepseek_r1_distill_llama_70b,
             .llama_3_2_1b_preview, .llama_3_2_3b_preview,
             .llama_3_2_11b_vision_preview, .llama_3_2_90b_vision_preview:
            return 128_000
        default:
            return nil
        }
    }

    static var productionModels: [GroqModel] {
        allCases.filter { !$0.isPreview }
    }

    static var previewModels: [GroqModel] {
        allCases.filter { $0.isPreview }
    }
}
