using UnityEngine;
using System.Collections;

public class CaretakerSpawner : MonoBehaviour
{
    public GameObject caretakerPrefab;
    public Transform[] spawnPoints;
    public Transform player;

    private GameObject currentCaretaker;
    private bool hasSpawned = false;

    void Start()
    {
        StartCoroutine(SpawnAfterDelay());
    }

    IEnumerator SpawnAfterDelay()
    {
        float wait = Random.Range(300f, 600f); // random delay before spawn
        Debug.Log($"[CaretakerSpawner] Waiting {wait:F1} seconds before spawn...");
        yield return new WaitForSeconds(wait);

        SpawnCaretaker();
    }

    void SpawnCaretaker()
    {
        // Prevent multiple spawns
        if (hasSpawned)
        {
            Debug.LogWarning("[CaretakerSpawner] Caretaker already spawned. Skipping.");
            return;
        }

        if (spawnPoints == null || spawnPoints.Length == 0)
        {
            Debug.LogError("[CaretakerSpawner] No spawn points assigned!");
            return;
        }

        Transform spawn = spawnPoints[Random.Range(0, spawnPoints.Length)];
        currentCaretaker = Instantiate(caretakerPrefab, spawn.position, Quaternion.identity);
        hasSpawned = true;

        Debug.Log($"[CaretakerSpawner] Spawned caretaker at {spawn.name}");

        // Link with heartbeat (optional)
        PlayerHeartbeat heartbeat = player.GetComponent<PlayerHeartbeat>();
        if (heartbeat != null)
        {
            heartbeat.caretaker = currentCaretaker.transform;
            Debug.Log("[CaretakerSpawner] Heartbeat now tracking caretaker.");
        }

        // Initialize caretaker AI (optional)
        var ai = currentCaretaker.GetComponent<CaretakerAI>();
        if (ai != null)
        {
            ai.Initialize(player);
        }
    }
}
