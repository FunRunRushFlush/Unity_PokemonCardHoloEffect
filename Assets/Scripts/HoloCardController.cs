using UnityEngine;

[ExecuteAlways]
public class HoloCardController : MonoBehaviour
{
    private static readonly int CardArtId = Shader.PropertyToID("_CardArt");
    private static readonly int FoilTexId = Shader.PropertyToID("_FoilTex");
    private static readonly int MaskTexId = Shader.PropertyToID("_MaskTex");
    private static readonly int GlitterTexId = Shader.PropertyToID("_GlitterTex");
    private static readonly int GrainTexId = Shader.PropertyToID("_GrainTex");
    private static readonly int PatternTexId = Shader.PropertyToID("_PatternTex");
    private static readonly int CosmosBottomTexId = Shader.PropertyToID("_CosmosBottomTex");
    private static readonly int CosmosMiddleTexId = Shader.PropertyToID("_CosmosMiddleTex");
    private static readonly int CosmosTopTexId = Shader.PropertyToID("_CosmosTopTex");
    private static readonly int HoloModeId = Shader.PropertyToID("_HoloMode");
    private static readonly int LayoutMaskModeId = Shader.PropertyToID("_LayoutMaskMode");
    private static readonly int UseMaskTexId = Shader.PropertyToID("_UseMaskTex");
    private static readonly int CardGlowColorId = Shader.PropertyToID("_CardGlowColor");
    private static readonly int FoilBrightnessId = Shader.PropertyToID("_FoilBrightness");
    private static readonly int EffectStrengthId = Shader.PropertyToID("_EffectStrength");
    private static readonly int SeedXId = Shader.PropertyToID("_SeedX");
    private static readonly int SeedYId = Shader.PropertyToID("_SeedY");

    [SerializeField] private Renderer cardFrontRenderer;
    [SerializeField] private HoloCardProfile profile;
    [SerializeField] private bool randomizeSeed = true;
    [SerializeField] private Vector2 seed = new Vector2(0.37f, 0.73f);

    private MaterialPropertyBlock propertyBlock;

    public HoloCardProfile Profile
    {
        get => profile;
        set
        {
            profile = value;
            ApplyProfile();
        }
    }

    private void Reset()
    {
        cardFrontRenderer = GetComponentInChildren<Renderer>();
    }

    private void Awake()
    {
        EnsureState();
        ApplyProfile();
    }

    private void OnEnable()
    {
        EnsureState();
        ApplyProfile();
    }

    private void OnValidate()
    {
        EnsureState();
        ApplyProfile();
    }

    private void EnsureState()
    {
        if (propertyBlock == null)
            propertyBlock = new MaterialPropertyBlock();

        if (cardFrontRenderer == null)
            cardFrontRenderer = GetComponentInChildren<Renderer>();

        if (randomizeSeed && seed == Vector2.zero)
            seed = new Vector2(Random.value, Random.value);
    }

    public void ApplyProfile()
    {
        if (cardFrontRenderer == null || profile == null)
            return;

        cardFrontRenderer.GetPropertyBlock(propertyBlock);

        SetTextureIfPresent(CardArtId, profile.cardArt);
        SetTextureIfPresent(FoilTexId, profile.foilTex);
        SetTextureIfPresent(MaskTexId, profile.maskTex);
        SetTextureIfPresent(GlitterTexId, profile.glitterTex);
        SetTextureIfPresent(GrainTexId, profile.grainTex);
        SetTextureIfPresent(PatternTexId, profile.patternTex);
        SetTextureIfPresent(CosmosBottomTexId, profile.cosmosBottomTex);
        SetTextureIfPresent(CosmosMiddleTexId, profile.cosmosMiddleTex);
        SetTextureIfPresent(CosmosTopTexId, profile.cosmosTopTex);

        propertyBlock.SetFloat(HoloModeId, (float)profile.holoMode);
        propertyBlock.SetFloat(LayoutMaskModeId, (float)profile.layoutMaskMode);
        propertyBlock.SetFloat(UseMaskTexId, profile.useMaskTex && profile.maskTex != null ? 1f : 0f);
        propertyBlock.SetColor(CardGlowColorId, profile.cardGlowColor);
        propertyBlock.SetFloat(FoilBrightnessId, profile.EffectiveFoilBrightness);
        propertyBlock.SetFloat(EffectStrengthId, profile.effectStrength);
        propertyBlock.SetFloat(SeedXId, seed.x);
        propertyBlock.SetFloat(SeedYId, seed.y);

        cardFrontRenderer.SetPropertyBlock(propertyBlock);
    }

    private void SetTextureIfPresent(int propertyId, Texture texture)
    {
        if (texture != null)
            propertyBlock.SetTexture(propertyId, texture);
    }
}
