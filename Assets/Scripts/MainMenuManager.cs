using UnityEngine;

public class MainMenuUI : MonoBehaviour
{
    [SerializeField] private GameObject mainMenuCanvas;

    void Start()
    {
        mainMenuCanvas.SetActive(true); // show menu at start
        Time.timeScale = 0f;           // pause game behind the menu
    }

    public void PlayGame()
    {
        mainMenuCanvas.SetActive(false);
        Time.timeScale = 1f;           // resume game
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
