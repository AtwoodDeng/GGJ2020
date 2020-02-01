using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectController : MonoBehaviour
{
    public GameObject WaveEffectPrefab;
    public int count = 100;

    // Start is called before the first frame update
    void Start()
    {
        for ( int i = 0; i < count; ++ i )
        {
            var wave = Instantiate(WaveEffectPrefab) as GameObject;
            wave.transform.parent = transform;
            wave.transform.localPosition = new Vector3(Random.Range(-10f, 10f), Random.Range(-0.1f,0.1f), 0);


            var rot = wave.GetComponent<RotateTween>();
            rot.circleTime = Random.Range(10, 25f) ;
            var radius = Random.Range(2.5f, 5f);
            rot.childCircle.transform.localScale = Vector3.one * radius;

            rot.childCircle.transform.localPosition = new Vector3(0, -radius * 0.5f , 0);

        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
