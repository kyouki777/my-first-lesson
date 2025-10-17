using UnityEngine;

public class ComputerZone : MonoBehaviour
{
    private GameManager gameManager;

    private void Start()
    {
        gameManager = FindObjectOfType<GameManager>();
    }

    private void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player") && gameManager.disableOnExit)
        {
            gameObject.SetActive(false);
        }
    }
}
