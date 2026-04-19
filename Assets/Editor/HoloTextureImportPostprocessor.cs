using UnityEditor;

public class HoloTextureImportPostprocessor : AssetPostprocessor
{
    private static readonly string[] RepeatTextureNames =
    {
        "ancient",
        "angular",
        "cosmos",
        "crossover",
        "galaxy",
        "geometric",
        "glitter",
        "illusion",
        "metal",
        "rainbow",
        "stylish",
        "trainerbg",
        "vmaxbg",
        "wave"
    };

    private void OnPreprocessTexture()
    {
        TextureImporter importer = assetImporter as TextureImporter;
        if (importer == null)
            return;

        string path = assetPath.Replace('\\', '/').ToLowerInvariant();
        bool isHoloTexture = path.Contains("assets/media/foileffects/");
        bool isMask = path.Contains("mask") || path.Contains("/masks/");

        if (isHoloTexture)
        {
            importer.wrapMode = isMask
                ? UnityEngine.TextureWrapMode.Clamp
                : UnityEngine.TextureWrapMode.Repeat;
            importer.filterMode = UnityEngine.FilterMode.Bilinear;
            return;
        }

        if (!path.Contains("assets/media/"))
            return;

        foreach (string textureName in RepeatTextureNames)
        {
            if (!path.Contains(textureName))
                continue;

            importer.wrapMode = UnityEngine.TextureWrapMode.Repeat;
            importer.filterMode = UnityEngine.FilterMode.Bilinear;
            return;
        }

        importer.wrapMode = UnityEngine.TextureWrapMode.Clamp;
        importer.filterMode = UnityEngine.FilterMode.Bilinear;
    }
}
