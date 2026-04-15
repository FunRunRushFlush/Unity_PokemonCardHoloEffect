using UnityEngine;

public class CardInteraction : MonoBehaviour
{
    [Header("Referenzen")]
    [SerializeField] private Transform cardTranslation;
    [SerializeField] private Transform cardRotation;
    [SerializeField] private Renderer cardFrontRenderer;
    [SerializeField] private Camera mainCamera;

    private SpringVector2 springRotate      = new SpringVector2(0.066f, 0.25f);
    private SpringVector3 springGlare       = new SpringVector3(0.066f, 0.25f);
    private SpringVector2 springBackground  = new SpringVector2(0.066f, 0.25f);
    private SpringFloat   springScale       = new SpringFloat(0.033f, 0.45f, 1f);
    private SpringVector2 springTranslate   = new SpringVector2(0.033f, 0.45f);
    private SpringVector2 springRotateDelta = new SpringVector2(0.033f, 0.45f);

    private MaterialPropertyBlock mpb;
    private bool isInteracting;

    // Exit-Buffer: verhindert sofortiges Zurücksetzen beim Verlassen des Rands
    private float exitTimer;
    [SerializeField] private float exitDelay = 0.15f; // Sekunden nach Verlassen bevor Reset

    // Oversized Raycast: größerer unsichtbarer Bereich für sanften Randübergang
    [SerializeField] private float colliderPadding = 0.05f;

    private void Awake()
    {
        mpb = new MaterialPropertyBlock();
        if (mainCamera == null)
            mainCamera = Camera.main;
    }

    private void Update()
    {
        HandleInput();
        UpdateSprings();
        ApplyTransform();
        ApplyShaderProperties();
    }

    private void HandleInput()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        bool hitCard = false;

        if (Physics.Raycast(ray, out RaycastHit hit) && hit.collider.gameObject == gameObject)
        {
            // Nutze die ROTIERTE Card-Position für korrekte UV-Berechnung
            Vector3 localPoint = cardRotation.InverseTransformPoint(hit.point);

            float percentX = (localPoint.x + 0.5f) * 100f;
            float percentY = (localPoint.y + 0.5f) * 100f;

            // Erweiterten Bereich akzeptieren (padding), aber Werte clampen
            if (percentX >= -colliderPadding * 100f && percentX <= 100f + colliderPadding * 100f &&
                percentY >= -colliderPadding * 100f && percentY <= 100f + colliderPadding * 100f)
            {
                hitCard = true;
                percentX = Mathf.Clamp(percentX, 0f, 100f);
                percentY = Mathf.Clamp(percentY, 0f, 100f);

                float rotX = (percentX - 50f) / 3.5f;
                float rotY = (percentY - 50f) / 3.5f;
                float bgX = Mathf.Lerp(37f, 63f, percentX / 100f);
                float bgY = Mathf.Lerp(37f, 63f, percentY / 100f);

                // Erster Frame der Interaktion: Shader-Positionen sofort snappen,
                // Opacity und Rotation dürfen sanft faden/animieren
                if (!isInteracting)
                {
                    // Nur Shader-Effekt-Positionen snappen (kein Blitz in der Mitte)
                    springGlare.x.current = percentX;
                    springGlare.y.current = percentY;
                    // z (Opacity) NICHT snappen → darf sanft von 0 auf 1 faden
                    springBackground.x.current = bgX;
                    springBackground.y.current = bgY;
                    // Rotation NICHT snappen → Karte neigt sich sanft
                }

                isInteracting = true;
                exitTimer = exitDelay;

                springRotate.SetTarget(rotX, rotY);
                springGlare.SetTarget(percentX, percentY, 1f);
                springBackground.SetTarget(bgX, bgY);
            }
        }

        if (!hitCard)
        {
            // Buffer: erst nach exitDelay auf Ruheposition zurücksetzen
            exitTimer -= Time.deltaTime;
            if (exitTimer <= 0f && isInteracting)
            {
                isInteracting = false;
                springRotate.SetTarget(0f, 0f);
                springGlare.SetTarget(50f, 50f, 0f);
                springBackground.SetTarget(50f, 50f);
                springScale.target = 1f;
                springTranslate.SetTarget(0f, 0f);
                springRotateDelta.SetTarget(0f, 0f);
            }
        }
    }

    private void UpdateSprings()
    {
        springRotate.Update();
        springGlare.Update();
        springBackground.Update();
        springScale.Update();
        springTranslate.Update();
        springRotateDelta.Update();
    }

    private void ApplyTransform()
    {
        cardTranslation.localPosition = new Vector3(
            springTranslate.x.current,
            springTranslate.y.current,
            springScale.current * 0.15f
        );
        cardTranslation.localScale = Vector3.one * springScale.current;

        float totalRotX = springRotate.x.current + springRotateDelta.x.current;
        float totalRotY = springRotate.y.current + springRotateDelta.y.current;
        cardRotation.localRotation = Quaternion.Euler(-totalRotY, totalRotX, 0f);
    }

    private void ApplyShaderProperties()
    {
        cardFrontRenderer.GetPropertyBlock(mpb);

        float px = springGlare.x.current / 100f;
        float py = springGlare.y.current / 100f;
        mpb.SetFloat("_PointerX", px);
        mpb.SetFloat("_PointerY", py);

        mpb.SetFloat("_BackgroundX", springBackground.x.current / 100f);
        mpb.SetFloat("_BackgroundY", springBackground.y.current / 100f);

        float fromCenter = Mathf.Sqrt(
            Mathf.Pow(px - 0.5f, 2f) + Mathf.Pow(py - 0.5f, 2f)
        ) / 0.5f;
        mpb.SetFloat("_PointerFromCenter", Mathf.Clamp01(fromCenter));
        mpb.SetFloat("_PointerFromLeft", px);
        mpb.SetFloat("_PointerFromTop", py);
        mpb.SetFloat("_CardOpacity", springGlare.z.current);

        cardFrontRenderer.SetPropertyBlock(mpb);
    }
}
