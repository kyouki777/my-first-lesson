using UnityEngine;
using UnityEngine.EventSystems;

public class PauseManager : MonoBehaviour
{
    [SerializeField] private GameObject pauseUI;
    [SerializeField] private GameObject mainMenuUI; //  Add this in Inspector

    public static bool IsPaused { get; private set; } = false;
    private bool isPaused = false;

    void Update()
    {
        //  Do nothing if main menu is visible
        if (mainMenuUI != null && mainMenuUI.activeSelf)
            return;

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (isPaused) ResumeGame();
            else PauseGame();
        }
    }

    public void PauseGame()
    {
        if (mainMenuUI != null && mainMenuUI.activeSelf) return; // extra safety

        pauseUI.SetActive(true);
        Time.timeScale = 0f;
        AudioListener.pause = true;
        IsPaused = true;
        isPaused = true;

        // Disable UI input to prevent unwanted clicks
        if (EventSystem.current != null)
            EventSystem.current.enabled = false;

        Debug.Log("[PauseManager] Game Paused.");
    }

    public void ResumeGame()
    {
        pauseUI.SetActive(false);
        Time.timeScale = 1f;
        AudioListener.pause = false;
        IsPaused = false;
        isPaused = false;

        if (EventSystem.current != null)
            EventSystem.current.enabled = true;

        Debug.Log("[PauseManager] Game Resumed.");
    }

    public void ExitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
        Debug.Log("[PauseManager] Exit button clicked.");
#else
        Application.Quit();
#endif
    }
}
