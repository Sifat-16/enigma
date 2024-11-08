package com.wakil_training_.enigma.models

data class PushBodyModel(
    val type: String = "",
    val body: String = "",
    val showNotification: Boolean = true
) {

    // Convert a PushBodyModel object to a JSON map
    fun toJson(): Map<String, Any> {
        return mapOf(
            "type" to type,
            "body" to body
        )
    }

    // Create a PushBodyModel object from a JSON map
    companion object {
        fun fromJson(json: Map<String, Any>): PushBodyModel {
            return PushBodyModel(
                type = json["type"] as String,
                body = json["body"] as String
            )
        }
    }
}
