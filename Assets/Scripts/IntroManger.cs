using UnityEngine;
using UnityEngine.SceneManagement;

public class IntroManager : MonoBehaviour
{
    public float autoLoadDelay = 10f; // Time in seconds before auto-loading next scene
    public string nextSceneName = "MainScene"; // Change to your main scene name

    private bool hasSkipped = false; // To prevent multiple triggers

    void Start()
    {
        // Automatically go to next scene after delay
        Invoke("LoadNextScene", autoLoadDelay);
    }

    void Update()
    {
        // Detect *any* key or mouse click to skip
        if (!hasSkipped && Input.anyKeyDown)
        {
            SkipIntro();
        }
    }

    public void SkipIntro()
    {
        if (hasSkipped) return; // Prevent double loading
        hasSkipped = true;

        Debug.Log("Intro skipped!");
        CancelInvoke("LoadNextScene"); // Stop auto-load if triggered
        LoadNextScene();
    }

    void LoadNextScene()
    {
        SceneManager.LoadScene(nextSceneName);
    }
}
