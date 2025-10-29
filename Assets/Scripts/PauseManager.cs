
// 10/26/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

using UnityEngine;

public class PauseManager : MonoBehaviour
{
    [Header("UI References")]
    public CanvasGroup pauseCanvasGroup;
    public GameObject mainMenuUI; // assign in Inspector\
    public GameObject pauseUI;

    private bool isPaused = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            // Don’t pause if the main menu is active
            if (mainMenuUI != null && mainMenuUI.activeSelf)
                return;

            TogglePause();
        }
    }

    void TogglePause()
    {
        isPaused = !isPaused;

        if (isPaused)
        {
            Debug.Log("Game paused");

            pauseUI.SetActive(true);
            AudioListener.pause = true;
            Time.timeScale = 0; // Pause the game
            pauseCanvasGroup.interactable = false; // Disable UI interaction
            pauseCanvasGroup.blocksRaycasts = false; // Prevent clicks
        }
        else
        {
            pauseUI.SetActive(false);
            AudioListener.pause = false;
            Debug.Log("Game resumed");
            Time.timeScale = 1; // Resume the game
            pauseCanvasGroup.interactable = true; // Enable UI interaction
            pauseCanvasGroup.blocksRaycasts = true; // Allow clicks
        }
    }
}


// 10/26/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

/*using UnityEngine;

public class PauseManager : MonoBehaviour
{
    public CanvasGroup pauseCanvasGroup;

    private bool isPaused = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape)) // Replace with your pause key
        {
            TogglePause();
        }
    }

    void TogglePause()
    {
        isPaused = !isPaused;

        if (isPaused)
        {
            Debug.Log("Game paused");

            AudioListener.pause = true;
            Time.timeScale = 0; // Pause the game
            pauseCanvasGroup.interactable = false; // Disable UI interaction
            pauseCanvasGroup.blocksRaycasts = false; // Prevent clicks
        }
        else
        {
            AudioListener.pause = false;
            Debug.Log("Game resumed");
            Time.timeScale = 1; // Resume the game
            pauseCanvasGroup.interactable = true; // Enable UI interaction
            pauseCanvasGroup.blocksRaycasts = true; // Allow clicks
        }
    }
}*/