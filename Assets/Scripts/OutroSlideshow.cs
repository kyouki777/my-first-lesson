using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class OutroSlideshow : MonoBehaviour
{
    [Header("Slides and Settings")]
    public CanvasGroup[] slides;
    public float fadeDuration = 1f;
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

        // Make sure all slides start invisible and active
        foreach (CanvasGroup cg in slides)
        {
            cg.alpha = 0f;
            cg.gameObject.SetActive(true);
        }

        // Loop through all slides
        for (currentIndex = 0; currentIndex < slides.Length; currentIndex++)
        {
            CanvasGroup slide = slides[currentIndex];

            Debug.Log($"[OutroSlideshow] Waiting for input to show slide {currentIndex + 1}/{slides.Length}...");
            yield return StartCoroutine(WaitForInput());

            // Fade in current slide
            Debug.Log($"[OutroSlideshow] Fading in slide {slide.gameObject.name}");
            yield return StartCoroutine(FadeSlide(slide, 0f, 1f));

            // Wait for input before moving to next
            Debug.Log("[OutroSlideshow] Waiting for input to continue...");
            yield return StartCoroutine(WaitForInput());

            // If not last, fade out before next
            if (currentIndex < slides.Length - 1)
            {
                Debug.Log($"[OutroSlideshow] Fading out slide {slide.gameObject.name}");
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

        while (timer < fadeDuration)
        {
            timer += Time.unscaledDeltaTime;
            cg.alpha = Mathf.Lerp(from, to, timer / fadeDuration);
            yield return null;
        }

        cg.alpha = to;
    }

    IEnumerator WaitForInput()
    {
        while (!Input.anyKeyDown && !Input.GetMouseButtonDown(0))
        {
            yield return null;
        }
    }

    public void OnSkipButtonPressed()
    {
        Debug.Log("[OutroSlideshow] Skip button pressed — loading MainScene immediately!");
        StopAllCoroutines();
        LoadMainScene();
    }

    public void LoadMainScene()
    {
        Debug.Log($"[OutroSlideshow] Loading main scene: {mainSceneName}");
        Time.timeScale = 1f;
        SceneManager.LoadScene(mainSceneName);
    }
}
