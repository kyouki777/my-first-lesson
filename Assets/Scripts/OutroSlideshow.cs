using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class OutroSlideshow : MonoBehaviour
{
    [Header("Slides and Settings")]
    public CanvasGroup[] slides;          // Assign in Inspector
    public float fadeDuration = 1f;       // How long fades take
    public string mainSceneName = "MainScene";

    private int currentIndex = 0;
    private bool isPlaying = false;

    void Start()
    {
        Debug.Log("[OutroSlideshow] Starting outro slideshow...");
        Time.timeScale = 0f; // Pause gameplay
        StartCoroutine(PlaySlides());
    }

    IEnumerator PlaySlides()
    {
        if (slides == null || slides.Length == 0)
        {
            Debug.LogWarning("[OutroSlideshow] No slides assigned!");
            yield break;
        }

        isPlaying = true;

        // Initialize all slides as invisible
        foreach (CanvasGroup cg in slides)
        {
            cg.alpha = 0f;
            cg.gameObject.SetActive(true); // make sure they're active
        }

        // Loop through all slides
        for (currentIndex = 0; currentIndex < slides.Length; currentIndex++)
        {
            CanvasGroup slide = slides[currentIndex];
            Debug.Log($"[OutroSlideshow] Fading in slide {currentIndex + 1}/{slides.Length}: {slide.gameObject.name}");
            yield return StartCoroutine(FadeSlide(slide, 0f, 1f));

            Debug.Log($"[OutroSlideshow] Slide {currentIndex + 1} fully visible. Waiting for player input...");

            // Wait for player input before continuing
            yield return StartCoroutine(WaitForInput());

            // If this is NOT the last slide, fade out before moving to next
            if (currentIndex < slides.Length - 1)
            {
                Debug.Log($"[OutroSlideshow] Fading out slide {currentIndex + 1}");
                yield return StartCoroutine(FadeSlide(slide, 1f, 0f));
            }
            else
            {
                Debug.Log("[OutroSlideshow] Last slide reached — staying on screen.");
            }
        }

        Debug.Log("[OutroSlideshow] Slideshow finished!");
    }

    IEnumerator FadeSlide(CanvasGroup cg, float from, float to)
    {
        float timer = 0f;
        cg.alpha = from;
        Debug.Log($"[OutroSlideshow] Fading {cg.gameObject.name} from {from} - {to}");

        while (timer < fadeDuration)
        {
            timer += Time.unscaledDeltaTime;
            cg.alpha = Mathf.Lerp(from, to, timer / fadeDuration);
            yield return null;
        }

        cg.alpha = to;
        Debug.Log($"[OutroSlideshow] Fade complete for {cg.gameObject.name}, alpha={cg.alpha}");
    }

    IEnumerator WaitForInput()
    {
        while (!Input.anyKeyDown && !Input.GetMouseButtonDown(0))
        {
            yield return null;
        }
        Debug.Log("[OutroSlideshow] Player input detected — moving to next slide.");
    }

    //  Button: Go to main scene (you can assign this to your button)
    public void OnSkipButtonPressed()
    {
        Debug.Log("[OutroSlideshow] Skip button pressed — loading MainScene immediately!");
        StopAllCoroutines();
        LoadMainScene();
    }

    public void LoadMainScene()
    {
        Debug.Log($"[OutroSlideshow] Loading main scene: {mainSceneName}");
        Time.timeScale = 1f; // Resume time before switching scenes
        SceneManager.LoadScene(mainSceneName);
    }
}
