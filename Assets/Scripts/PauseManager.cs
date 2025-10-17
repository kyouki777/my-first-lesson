using UnityEngine;

public class PauseManager : MonoBehaviour
{
    [SerializeField] private GameObject pauseUI;

    private bool isPaused = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape)) // Or whatever key you want
        {
            if (isPaused) ResumeGame();
            else PauseGame();
        }
    }

    public void PauseGame()
    {
        pauseUI.SetActive(true);        // Show UI
        Time.timeScale = 0f;            // Stop all gameplay
        isPaused = true;
    }

    public void ResumeGame()
    {
        pauseUI.SetActive(false);       // Hide UI
        Time.timeScale = 1f;            // Resume gameplay
        isPaused = false;
    }

    // Call this from a UI button
    public void ExitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false; // Stops play mode in editor
#else
        Application.Quit(); // Exits the built game
#endif
    }
}
