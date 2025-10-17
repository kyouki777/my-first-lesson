using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections;

public class GameOverManager : MonoBehaviour
{
    [Header("Game Over UI")]
    public CanvasGroup gameOverUI; // Assign your UI panel (with CanvasGroup)
    public float fadeDuration = 1.5f;

    private bool isGameOver = false;

    public void TriggerGameOver()
    {
        if (isGameOver) return;
        isGameOver = true;

        StartCoroutine(GameOverSequence());
    }

    private IEnumerator GameOverSequence()
    {
        // Pause the game
        Time.timeScale = 0f;

        // Activate UI
        gameOverUI.gameObject.SetActive(true);
        gameOverUI.alpha = 0f;

        float elapsed = 0f;

        // Fade in with unscaled deltaTime (still works while paused)
        while (elapsed < fadeDuration)
        {
            elapsed += Time.unscaledDeltaTime;
            gameOverUI.alpha = Mathf.Lerp(0f, 1f, elapsed / fadeDuration);
            yield return null;
        }

        gameOverUI.alpha = 1f;
    }

    public void RestartGame()
    {
        Time.timeScale = 1f; // Resume before reload
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
