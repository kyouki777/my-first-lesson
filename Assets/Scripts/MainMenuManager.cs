using UnityEngine;

public class MainMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject mainMenuCanvas;
    [SerializeField] private AudioSource menuMusic; // assign in Inspector

    void Start()
    {
        mainMenuCanvas.SetActive(true);
        Time.timeScale = 0f; // pause game behind the menu

        if (menuMusic != null && !menuMusic.isPlaying)
        {
            menuMusic.Play();
        }
    }

    public void PlayGame()
    {
        mainMenuCanvas.SetActive(false);
        Time.timeScale = 1f;

        if (menuMusic != null && menuMusic.isPlaying)
        {
            menuMusic.Stop(); // stop music when entering the game
        }
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
