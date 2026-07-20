shader_type canvas_item;

uniform sampler2D overlay_tex : repeat_enable, filter_nearest;

// Taille de la texture (1 / taille)
// Exemple : texture de 144 px -> 1.0 / 144.0 = 0.006944444
instance uniform float scale = 0.00390625;

// Décalage de la texture (en pixels monde)
instance uniform vec2 offset = vec2(0.0);

// Couleur à remplacer
instance uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Tolérance de comparaison
uniform float tolerance = 0.01;

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {

    // Compare la couleur du pixel avec la couleur cible
    float mix_amount = (
        length(COLOR.rgb - target_color.rgb) < tolerance
    ) ? 1.0 : 0.0;

    // Aligne les coordonnées sur la grille de pixels
    vec2 pos = floor(world_position);

    // Ajoute l'offset
    vec2 uv = (pos + offset) * scale;

    // Lit la texture overlay
    vec4 overlay_color = texture(overlay_tex, uv);

    // Remplace la couleur
    COLOR = mix(COLOR, overlay_color, mix_amount);
}