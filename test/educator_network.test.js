//import { AssertionError } from "assert";

let EducatorNetwork = artifacts.require('EducatorNetwork')
let BN = web3.utils.BN


contract('EducatorNetwork', function(accounts){
    const instructor1 = accounts[0]
    const instructor2 = accounts[1]
    const student1 = accounts[2]
    const student2 = accounts[3]

    let instance 

    beforeEach(async () =>{
        instance = await EducatorNetwork.new()
    })

    it("Should store two videos and checking the passed details are correct", async() =>{
        let videoId = await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        console.log('Received from addVideo', videoId)
        let result = await instance.getVideo(0)
        console.log('Received from getVideo', result)
        assert.equal(result[0].toString(), instructor1.toString(), "Not uploaded by instructor 1")
        assert.equal(result[1].toString(), "solidity tutorial", "Doesn't match description passed")
       // assert.equal(videoId.valueOf(), 0, "VideoId for first video added is not 0")

       let videoId2 = await instance.addVideo(100, "react tutorial", "ipfs.com/video2", {from: instructor2})
        console.log('Received from addVideo', videoId)
        let result2 = await instance.getVideo(1)
        console.log('Received from getVideo', result)
        assert.equal(result[0].toString(), instructor2.toString(), "Not uploaded by instructor 2")
        assert.equal(result[1].toString(), "react tutorial", "Doesn't match description passed")
    })


    // it("Should store a second video and return video Id of 1", async() =>{
    //     let videoId2 = await instance.addVideo(100, "react tutorial", "ipfs.com/video2", {from: instructor2})
    //     console.log('Received from addVideo', videoId)
    //     let result2 = await instance.getVideo(0)
    //     console.log('Received from getVideo', result)
    //     assert.equal(result[0].toString(), instructor2.toString(), "Not uploaded by instructor 2")
    //     assert.equal(result[1].toString(), "react tutorial", "Doesn't match description passed")
    // })


})