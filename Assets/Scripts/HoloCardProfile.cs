using UnityEngine;

[CreateAssetMenu(menuName = "Holo Cards/Holo Card Profile", fileName = "HoloCardProfile")]
public class HoloCardProfile : ScriptableObject
{
    [Header("Recipe")]
    public HoloMode holoMode = HoloMode.RegularHolo;
    public LayoutMaskMode layoutMaskMode = LayoutMaskMode.ArtworkWindow;
    public PokemonType pokemonType = PokemonType.Colorless;

    [Header("Textures")]
    public Texture2D cardArt;
    public Texture2D foilTex;
    public Texture2D maskTex;
    public Texture2D glitterTex;
    public Texture2D grainTex;
    public Texture2D patternTex;
    public Texture2D cosmosBottomTex;
    public Texture2D cosmosMiddleTex;
    public Texture2D cosmosTopTex;

    [Header("Tuning")]
    public Color cardGlowColor = new Color(0.75f, 1f, 1f, 1f);
    [Range(0f, 2f)] public float foilBrightness = 0f;
    [Range(0f, 3f)] public float effectStrength = 1f;
    public bool useMaskTex = true;

    public float EffectiveFoilBrightness
    {
        get
        {
            if (foilBrightness > 0f)
                return foilBrightness;

            switch (pokemonType)
            {
                case PokemonType.Lightning:
                    return 0.7f;
                case PokemonType.Darkness:
                    return 0.8f;
                case PokemonType.Metal:
                    return 0.6f;
                default:
                    return 0.55f;
            }
        }
    }
}
