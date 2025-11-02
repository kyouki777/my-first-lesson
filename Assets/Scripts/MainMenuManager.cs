using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject mainMenuCanvas;
    [SerializeField] private AudioSource menuMusic; // assign in Inspector
    [SerializeField] private DialogueManager dialogueManager; // Drag this in Inspector
    [SerializeField] private ItemDialogue startDialogue;      // Dialogue shown at Start
    public GameObject gameManagerObject; // assign in Inspector

    void Start()
    {
        mainMenuCanvas.SetActive(true);
        Time.timeScale = 0f; // pause game behind the menu

        if (menuMusic != null && !menuMusic.isPlaying)
        {
            menuMusic.Play();
        }
    }

    public void PlayStoryMode()
    {
        GameModeSelector.SelectedMode = GameMode.Story;
        StartGame();
    }

    public void PlayEndlessMode()
    {
        GameModeSelector.SelectedMode = GameMode.Endless;

        mainMenuCanvas.SetActive(false);
        Time.timeScale = 1f;

        if (menuMusic != null && menuMusic.isPlaying)
            menuMusic.Stop();

        // Activate GameManager AFTER selecting mode
        gameManagerObject.SetActive(true);

        Debug.Log("Endless Mode Started! SelectedMode = " + GameModeSelector.SelectedMode);
    }


    private void StartGame()
    {
        Debug.Log("[GameManager] StartGame() — Mode: " + GameModeSelector.SelectedMode);

        mainMenuCanvas.SetActive(false);
        Time.timeScale = 1f;

        if (menuMusic != null && menuMusic.isPlaying)
            menuMusic.Stop();

        if (GameModeSelector.SelectedMode == GameMode.Story)
        {
            if (dialogueManager != null && startDialogue != null)
                dialogueManager.StartDialogue(startDialogue);
            else
                Debug.LogWarning("DialogueManager or startDialogue not assigned in MainMenuManager.");
        }

        Debug.Log($"Game started in {GameModeSelector.SelectedMode} mode.");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
