using UnityEngine;

public class EscapeZone : MonoBehaviour
{
    public GameManager gameManager; // assign in Inspector
    private GameOverManager gameOverManager;

    void Start()
    {
        // Automatically find GameOverManager in scene
        gameOverManager = FindAnyObjectByType<GameOverManager>();
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player") && (gameOverManager == null || !gameOverManager.isGameOver))
        {
            // Player reached the escape zone and it's not game over
            Debug.Log("Player wins!");
            gameManager.PlayerWins();
        }
    }
}
