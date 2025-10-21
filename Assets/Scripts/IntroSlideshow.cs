using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement; //  Add this

public class IntroSlideshow : MonoBehaviour
{
    [Header("Slides")]
    public CanvasGroup[] slides;

    [Header("Timing")]
    public float fadeDuration = 1.5f;
    public float displayDuration = 2.5f;

    [Header("After Slideshow")]
    public GameObject nextCanvas; // Optional, if you want a menu instead of loading a scene
    public string nextSceneName;  //  Add your main scene name here (optional)

    void Start()
    {
        StartCoroutine(PlaySlideshow());
    }

    IEnumerator PlaySlideshow()
    {
        // loop through each slide
        for (int i = 0; i < slides.Length; i++)
        {
            yield return StartCoroutine(FadeIn(slides[i]));
            yield return new WaitForSeconds(displayDuration);
            yield return StartCoroutine(FadeOut(slides[i]));
        }

        // after slideshow ends
        gameObject.SetActive(false);

        //  If nextCanvas is assigned, show it (optional)
        if (nextCanvas != null)
            nextCanvas.SetActive(true);

        //  If nextSceneName is not empty, load it
        if (!string.IsNullOrEmpty(nextSceneName))
            SceneManager.LoadScene(nextSceneName);
    }

    IEnumerator FadeIn(CanvasGroup cg)
    {
        float t = 0f;
        while (t < fadeDuration)
        {
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
            t += Time.deltaTime;
            cg.alpha = Mathf.Lerp(1, 0, t / fadeDuration);
            yield return null;
        }
        cg.alpha = 0f;
    }
}
