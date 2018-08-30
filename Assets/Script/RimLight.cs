using UnityEngine;
using System.Collections;

public class RimLight : MonoBehaviour {

    Material mat;
	// Use this for initialization
	void Start () {
        mat = GetComponent<MeshRenderer>().material;
        mat.SetFloat("_CurrentTime",Time.timeSinceLevelLoad);
        StartCoroutine(SetTime());
	}

    IEnumerator SetTime()
    {
        while (true)
        {
            yield return new WaitForSeconds(1f);

            mat.SetFloat("_CurrentTime", Time.timeSinceLevelLoad);
        }
    }
}
