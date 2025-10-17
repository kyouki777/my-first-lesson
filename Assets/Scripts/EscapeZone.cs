using UnityEngine;

public class EscapeZone : MonoBehaviour
{
    public GameManager gameManager; // assign your GameManager in inspector

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            // Player reached the escape zone
            Debug.Log("Player wins!");
            gameManager.PlayerWins();
        }
    }
}
