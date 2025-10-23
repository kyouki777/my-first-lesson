using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class IntroSlideshow : MonoBehaviour
{
    [Header("Slides")]
    public CanvasGroup[] slides;

    [Header("Timing")]
    public float fadeDuration = 1.5f;
    public float displayDuration = 2.5f;

    [Header("Audio")]
    public AudioSource audioSource;
    public AudioClip openBookSound;
    public AudioClip closeBookSound;
    public AudioClip pageTurnSound;

    [Header("After Slideshow")]
    public GameObject nextCanvas; // Optional
    public string nextSceneName;  // Optional

    private bool canClick = false;
    private bool skipRequested = false;
    private int currentSlide = 0;

    void Start()
    {
        // Prepare all slides
        foreach (CanvasGroup cg in slides)
        {
            cg.alpha = 0f;
            cg.blocksRaycasts = false; // Prevent blocking clicks
            cg.gameObject.SetActive(true);
        }

        StartCoroutine(PlayIntro());
    }

    void Update()
    {
        // Press ESC to skip
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            SkipSlideshow();
        }
    }

    IEnumerator PlayIntro()
    {
        // --- First Slide (auto fade in/out) ---
        if (slides.Length > 0)
        {
            PlaySound(openBookSound);
            yield return StartCoroutine(FadeIn(slides[0]));
            yield return new WaitForSeconds(displayDuration);
            yield return StartCoroutine(FadeOut(slides[0]));
        }

        // --- Remaining Slides (manual click to continue) ---
        for (int i = 1; i < slides.Length; i++)
        {
            if (skipRequested) break;

            currentSlide = i;
            PlaySound(pageTurnSound);
            yield return StartCoroutine(FadeIn(slides[i]));

            canClick = true;
            yield return new WaitUntil(() =>
                Input.GetMouseButtonDown(0) ||
                Input.GetKeyDown(KeyCode.Space) ||
                skipRequested);
            canClick = false;

            if (skipRequested) break;
            yield return StartCoroutine(FadeOut(slides[i]));
        }

        // --- End of slideshow ---
        PlaySound(closeBookSound);
        yield return new WaitForSeconds(1f);

        if (nextCanvas != null)
            nextCanvas.SetActive(true);

        if (!string.IsNullOrEmpty(nextSceneName))
            SceneManager.LoadScene(nextSceneName);

        gameObject.SetActive(false);
    }

    IEnumerator FadeIn(CanvasGroup cg)
    {
        float t = 0f;
        while (t < fadeDuration)
        {
            if (skipRequested) yield break;
            t += Time.deltaTime;
            cg.alpha = Mathf.Lerp(0, 1, t / fadeDuration);
            yield return null;
        }
        cg.alpha = 1f;
    }

    IEnumerator FadeOut(CanvasGroup cg)
    {
        float t = 0f;
        while (t < fadeDuration)
        {
            if (skipRequested) yield break;
            t += Time.deltaTime;
            cg.alpha = Mathf.Lerp(1, 0, t / fadeDuration);
            yield return null;
        }
        cg.alpha = 0f;
    }

    private void PlaySound(AudioClip clip)
    {
        if (audioSource != null && clip != null)
            audioSource.PlayOneShot(clip);
    }

    public void SkipSlideshow()
    {
        if (skipRequested) return;
        skipRequested = true;
        Debug.Log(" ESC pressed — skipping slideshow!");
    }
}
