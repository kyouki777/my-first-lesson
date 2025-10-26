using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class IntroSlideshow : MonoBehaviour
{
    [Header("Slides")]
    public CanvasGroup[] slides;

    [Header("Timing")]
    public float fadeDuration = 1.5f;

    [Header("Audio")]
    public AudioSource audioSource;
    public AudioClip openBookSound;
    public AudioClip closeBookSound;
    public AudioClip pageTurnSound;

    [Header("After Slideshow")]
    public GameObject nextCanvas; // Optional
    public string nextSceneName;  // Optional

    private bool skipRequested = false;

    void Start()
    {
        // Hide all slides at start
        foreach (CanvasGroup cg in slides)
        {
            cg.alpha = 0f;
            cg.gameObject.SetActive(true);
        }

        StartCoroutine(PlayIntro());
    }

    void Update()
    {
        // ESC to skip
        if (Input.GetKeyDown(KeyCode.Escape))
            SkipSlideshow();
    }

    IEnumerator PlayIntro()
    {
        for (int i = 0; i < slides.Length; i++)
        {
            if (skipRequested) break;

            //  play proper sound
            if (i == 0) PlaySound(openBookSound);
            else PlaySound(pageTurnSound);

            //  fade in
            yield return StartCoroutine(FadeIn(slides[i]));

            //  wait for player input
            yield return new WaitUntil(() =>
                Input.GetMouseButtonDown(0) ||
                Input.GetKeyDown(KeyCode.Space) ||
                skipRequested);

            if (skipRequested) break;

            //  fade out
            yield return StartCoroutine(FadeOut(slides[i]));
        }

        //  closing sound
        PlaySound(closeBookSound);
        yield return new WaitForSeconds(1f);

        // move to next UI/scene
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
        Debug.Log("ESC pressed — skipping slideshow!");
    }
}
