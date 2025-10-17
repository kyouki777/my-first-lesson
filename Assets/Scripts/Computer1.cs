using UnityEngine;

public class Computer1 : MonoBehaviour
{
    public GameObject uiPanel; // assign in Inspector
    private bool playerInZone = false;

    void Update()
    {
        if (playerInZone && Input.GetKeyDown(KeyCode.E))
        {
            uiPanel.SetActive(!uiPanel.activeSelf);
            Debug.Log("Toggled UI!");
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = true;
            Debug.Log("Player entered zone");
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = false;
            uiPanel.SetActive(false);
            Debug.Log("Player left zone");
        }
    }
}


